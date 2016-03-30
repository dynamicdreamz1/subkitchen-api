ActiveAdmin.register EmailTemplate do
  permit_params :content, :subject
  config.filters = false
  config.batch_actions = false
  actions :index, :edit, :update, :show

  index do
    column(:name)
    column 'Description' do |template|
      truncate(template.description, length: 150, escape: false)
    end
    column(:subject)
    column 'Content' do |template|
      truncate(template.content, length: 150, escape: false)
    end
    actions
  end

  member_action :send_email, method: :post do
    emails = params[:emails].strip.split(';')
    redirect_to admin_email_template_path(params[:template]), notice: 'Email has been send'
  end

  show do |template|
    attributes_table do
      row(:name)
      row(:description)
      row(:subject)
      row 'Content' do
        raw(template.content)
      end
    end
    panel 'Send test email' do
      form(method: :post, action: send_email_admin_email_template_path(template: template)) do |f|
        f.input type: :hidden, value: form_authenticity_token, name: :authenticity_token
        f.input :email, as: :string, name: :email
        f.input type: :submit, value: 'Send'
      end
    end
  end

  form do |f|
    f.inputs 'Email Template' do
      f.input :subject, as: :string
      f.input :content, as: :wysihtml5
      f.submit
    end
  end
end
