describe Newsletters::Api, type: :request do
  it 'should create new newsletter receiver' do
    post '/api/v1/newsletter_receivers', { newsletter_receiver: { email: 'test@example.com' } }

    expect(response).to have_http_status(:success)
    expect(NewsletterReceiver.count).to eq(1)
  end

  it 'should return error when newsletter receiver exists' do
    receiver = create(:newsletter_receiver)
    post '/api/v1/newsletter_receivers', { newsletter_receiver: { email: receiver.email } }

    expect(response).to have_http_status(:unprocessable_entity)
    expect(json['errors']).to eq('base' => ['Validation failed: Email has already been taken'])
  end

  it 'should delete newsletter receiver' do
    create(:newsletter_receiver)
    receiver = create(:newsletter_receiver)
    delete '/api/v1/newsletter_receivers', { newsletter_receiver: { email: receiver.email } }

    expect(response).to have_http_status(:success)
    expect(NewsletterReceiver.count).to eq(1)
  end

  it 'should return error when newsletter receiver does not exist' do
    delete '/api/v1/newsletter_receivers', { newsletter_receiver: { email: 'test@example.com' } }

    expect(response).to have_http_status(:not_found)
    expect(json['errors']).to eq('base' => ['record not found'])
  end
end
