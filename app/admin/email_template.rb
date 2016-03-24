ActiveAdmin.register EmailTemplate do
  permit_params :content
  config.filters = false
  config.batch_actions = false
  actions :index, :edit, :update, :show

  index do
    column(:name)
    column 'Description' do |template|
      truncate(template.description, length: 150, escape: false)
    end
    column 'Content' do |template|
      truncate(template.content, length: 150, escape: false)
    end
    actions
  end

  show do |template|
    attributes_table do
      row(:name)
      row(:description)
      row 'Content' do
        raw(template.content)
      end
    end
  end

  form do |f|
    f.inputs 'Email Template' do
      f.input :content, as: :html_editor
      f.actions
    end
  end
end
