describe 'Through6' do
  let(:image){ fixture_file_upload(Rails.root.join('app/assets/images/sizechart-hoodie.jpg'), 'image/jpg') }
  let(:design){ fixture_file_upload(Rails.root.join('app/assets/images/design.pdf'), 'application/pdf') }

  before(:all) do
    create(:config, name: 'tax', value: '6')
    create(:config, name: 'shipping_cost', value: '7.00')
    create(:config, name: 'shipping_info', value: 'info')
    order = create(:order,
                   full_name: 'Klara Hirao',
                   address: 'Kaliskiego 100',
                   city: 'Warszawa',
                   zip: '00-000',
                   region: 'mazowieckie',
                   country: 'Polska',
    )
  end

  it 'should send request' do
    VCR.use_cassette('through6/valid') do
      create(:order_item, order: order, product: create(:product, image: image, design: design))

      order.reload
      SendOrder.new(order).call
    end
  end
end
