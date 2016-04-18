ActiveAdmin.register Color do
  permit_params :name, :color_value
  config.filters = false
  config.batch_actions = false
  actions :all

  index do
    column 'Color' do |color|
      color.name.humanize
    end
    column 'Image' do |color|
      "<div style='width:50px; height:50px; background-color:#{color.color_value}'></div>".html_safe
    end
    actions
  end

  show do |color|
    attributes_table do
      row 'Color' do
        color.name.humanize
      end
      row 'Image' do
        "<div style='width:50px; height:50px; background-color:#{color.color_value}'></div>".html_safe
      end
    end
  end

  form do |f|
    f.inputs 'Config', multipart: true do
      f.input :name
      f.input :color_value, as: :minicolors_picker
      f.actions
    end
  end
end
