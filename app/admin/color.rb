ActiveAdmin.register Color do
  permit_params :name, :color_value
  config.filters = false
  config.batch_actions = false
  actions :all, except: :show

  index do
    column 'Color' do |color|
      color.name.humanize
    end
    column 'Hex Color' do |color|
      color.color_value
    end
    column 'Preview' do |color|
      "<div style='width:50px; height:50px; background-color:#{color.color_value}'></div>".html_safe
    end
    actions
  end

  form do |f|
    f.inputs 'Config', multipart: true do
      f.input :name
      f.input :color_value, as: :minicolors_picker
      f.actions
    end
  end
end
