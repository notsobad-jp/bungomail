class BookAssignmentPolicy < ApplicationPolicy
  # Basicプラン || ( トライアル開始前 && トライアル開始日 < 配信開始日 )
  def create?
    user.basic_plan? || ( Date.current < user.trial_start_date && user.trial_start_date < record.start_date )
  end

  # 配信のオーナー && 公式配信以外
  def destroy?
    record.user == user && !record.user.admin?
  end
end
