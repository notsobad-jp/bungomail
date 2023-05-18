class BookAssignmentPolicy < ApplicationPolicy
  # Basicプラン(トライアル中含む) || トライアル予約済み
  def create?
    user.basic_plan? || user.trial_scheduled?
  end

  # 配信のオーナー
  def destroy?
    record.user == user
  end
end
