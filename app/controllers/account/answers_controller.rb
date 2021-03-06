class Account::AnswersController < AccountController
  before_action :set_answer, only: %i(show edit update destroy publish_hidden subscribe_answers)
  layout 'user_center', only: %i(index show edit)
  def index
    @answers = current_user.answers.published
    @answers = @answers.paginate(page: params[:page], per_page: 10)
    drop_breadcrumb("首页", show_profile_account_user_path(current_user))
    drop_breadcrumb("我回答的问题")
  end

  def show
    drop_breadcrumb("首页", show_profile_account_user_path(current_user))
    drop_breadcrumb("我回答的问题", account_answers_path(@answer))
    drop_breadcrumb("我的回答")
    @question = @answer.question
    @refer_questions = Question.published.where(status: "open").order("watches DESC").limit(3)
  end

  def new
    @answer = Answer.new
    @question = Question.find(params[:question_id])
  end

  def edit
    @question = @answer.question
    @question.watches_counter!
    drop_breadcrumb("我回答的问题", account_answers_path(@answer))
    drop_breadcrumb("修改我的回答")
  end

  def create
    @answer = Answer.new(answer_params)
    @question = Question.find(params[:question_id])
    @answer.user = current_user
    @answer.question = @question

    if @answer.save
      redirect_to account_answer_path(@answer), notice: "回答已发送！"
    else
      render :new
    end
  end

  def update
    if @answer.update(answer_params)
      redirect_to account_answer_path(@answer), notice: "回答已更新！"
    else
      render :edit
    end
  end

  def publish_hidden
    is_hidden = params[:is_hidden]
    @answer.is_hidden =
      if is_hidden == "publish"
        false
      else
        true
      end

    if @answer.save
      flash[:notice] = "操作成功！"
    else
      flash[:alert] = "操作失败！"
    end

    redirect_to :back
  end

  def subscribe_answers
    if @answer.user == current_user
      flash[:alert] = "不能偷听自己的回答！"
      redirect_to :back
      return
    end
    if current_user.subscribed_answer?(@answer)
      flash[:alert] = "您已经购买过答案，可以直接偷听"
      redirect_to my_subscriptions_account_user_path(current_user)
      return
    end
    if current_user.subscribe!(@answer)
      @answer_subscription = @answer.answer_subscriptions.where(user_id: current_user).first
      @answer_subscription.payment_method = params[:answer_subscription][:payment_method]
      @answer_subscription.save
      RewardAnswerSubscription.new(current_user, @answer.user, @answer.question.user, @answer).perform!
      flash[:notice] = "可以偷听答案了！"
    else
      flash[:alert] = "偷听不成功"
    end
    redirect_to :back
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_answer
    @answer = Answer.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def answer_params
    params.require(:answer).permit(:content)
  end

  # def answer_subscription_params
  #   params.require(:answer_subscription).permit(:payment_method)
  # end
end
