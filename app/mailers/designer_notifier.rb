class DesignerNotifier < ApplicationMailer
  def self.notify_designers(products)
    designers = Config.designers.strip.split(';')
    designers.each do |designer_email|
      notify_designer(products.to_a, designer_email).deliver_later
    end
  end

  def notify_designer(products , designer_email)
    @products = products
    mail to: designer_email, subject: 'New products are waiting for design'
  end
end
