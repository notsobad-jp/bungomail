class BookAssignmentPolicy < ApplicationPolicy
  # Basicプラン(トライアル中含む) || トライアル予約済み
  def create?
    user.basic_plan? || user.trial_scheduled?
  end

  # 配信のオーナー && 公式配信以外
  def destroy?
    record.user == user && !record.user.admin?
  end
end
