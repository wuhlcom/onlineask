class Admin::AnswersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_is_admin
  layout "admin"


  def index
    @answers = Answer.all
    drop_breadcrumb("答案管理")
  end

  def show
    @answer = Answer.find(params[:id])
    drop_breadcrumb("答案管理", admin_answers_path)
    drop_breadcrumb(@answer.question.title)
  end

  def hide
    @answer = Answer.find(params[:id])
    @answer.hide!
    flash[:alert] = "你隐藏了回答#{@answer.content}"
    redirect_to :back
  end

  def publish
    @answer = Answer.find(params[:id])
    @answer.publish!
    flash[:alert] = "你公开了回答#{@answer.content}"
    redirect_to :back
  end
end
