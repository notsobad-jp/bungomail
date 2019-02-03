class ChargePolicy < ApplicationPolicy
  def index?
    false
  end

  def show?
    false
  end

  def create?
    user && (!user.charge || user.charge.status == 'canceled')
  end

  def destroy?
    update? && record.status != 'canceled' && record.cancel_at.blank?
  end

  def activate?
    update? && record.status != 'canceled' && record.cancel_at.present?
  end

  def update_payment?
    user && user.charge
  end
end
