require 'rails_helper'

RSpec.describe ActiveAdmin do
  let(:all_resources)  { ActiveAdmin.application.namespaces[:admin].resources }
  let(:config_klass) { Config }
  let(:config) { all_resources[config_klass] }

  it 'should have actions' do
    expect(config.defined_actions).to eq([:index, :update, :edit, :show])
  end

  it 'should have name' do
    expect(config.resource_name).to eq('Config')
  end
end
