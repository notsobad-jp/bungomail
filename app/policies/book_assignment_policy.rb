class BookAssignmentPolicy < ApplicationPolicy
  # Basicプラン || ( トライアル開始前 && トライアル開始日 < 配信開始日 )
  def create?
    user && user.basic?
  end
end
