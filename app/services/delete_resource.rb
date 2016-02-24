class DeleteResource
  def call
    delete
  end

  private

  def initialize(resource)
    @resource = resource
  end

  def delete
    @resource.update_attribute(:is_deleted, true)
  end
end