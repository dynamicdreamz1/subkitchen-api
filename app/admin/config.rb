ActiveAdmin.register Config do
  permit_params :value, :config_image
  config.filters = false
  config.batch_actions = false
  actions :all, except: [:destroy, :create, :new]

  index do
    column 'Config' do |config|
      config.name.humanize
    end
    column 'Value' do |config|
      if config.config_image_id
        attachment_image_tag(config, :config_image, :fit, 50, 50)
      else
        truncate(config.value, length: 150, escape: false)
      end
    end
    actions
  end

  show do |config|
    attributes_table do
      row 'Config' do
        config.name.humanize
      end
      row 'Value' do
        if config.config_image_id
          attachment_image_tag(config, :config_image, :fit, 300, 300)
        else
          raw(config.value)
        end
      end
    end
  end

  form do |f|
    f.inputs 'Config', multipart: true do
      case f.object.input_type
      when 'long_text'
        f.input :value, as: :wysihtml5
      when 'short_text'
        f.input :value
      when 'image'
        f.input :config_image, as: :refile
      end
      f.actions
    end
  end
end
