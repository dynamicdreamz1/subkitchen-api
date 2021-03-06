describe 'Through6' do
  let(:image) { fixture_file_upload(Rails.root.join('app/assets/images/1024x1024.png'), 'image/png') }
  let(:design) { fixture_file_upload(Rails.root.join('app/assets/images/design.pdf'), 'application/pdf') }

  before(:each) do
    @order = create(:order,
      full_name: 'Klara Hirao',
      address: 'Kaliskiego 100',
      city: 'Warszawa',
      zip: '00-000',
      region: 'mazowieckie',
      country: 'Polska')
  end

  it 'should match valid api response' do
    VCR.use_cassette('through6/valid') do
      product = create(:product, image: image)
      create(:product_variant, product: product, size: "MD", design: design)
      create(:order_item, size: "MD", order: @order, product: product)
      @order.reload
      response = SendOrder.new(@order).call

      expect(response.code).to eq(200)
    end
  end

  it 'should return valid response' do
    product = create(:product, image: image)
    create(:product_variant, product: product, size: "MD", design: design)
    create(:order_item, size: "MD", order: @order, product: product)
    @order.reload
    serialized_order = Through6Serializer.new(@order).as_json

    stub = stub_request(:post, 'http://t6ordertest.azurewebsites.net/api/createorder').with(body: serialized_order)

    response = HTTP.basic_auth(user: 'subkitchen', pass: 'Pass1word').post(Figaro.env.t6_endpoint, json: serialized_order)

    expect(response.code).to eq(200)
    expect(stub).to have_been_requested
  end
end
