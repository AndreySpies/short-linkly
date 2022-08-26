require 'rails_helper'

RSpec.describe ShortLinksController, type: :controller do
  describe 'GET #show' do
    let!(:short_link) { create(:short_link) }
    let(:request) { get :show, params: { id: short_link.encoded_id, user_id: 1 } }
    let(:request2) { get :show, params: { id: short_link.encoded_id, user_id: 1 } }

    context 'with a valid short link' do
      it 'responds with a 301' do
        request
        expect(response).to have_http_status(:moved_permanently)
      end

      it 'redirects to the long_url' do
        expect(request).to redirect_to(short_link.long_link)
      end
    end

    context 'with a missing short_link' do
      before(:each) do
        allow(ShortLink).to receive(:find_by_encoded_id).and_return(nil)
      end

      it 'returns a 404' do
        request
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'analytics' do
      it 'has increased accessess' do
        request
        request2
        expect(ShortLink.first.accesses).to eq(2)
      end

      it 'has not increased accessess' do
        expect(ShortLink.first.accesses).to eq(0)
      end
    end
  end

  describe 'POST #create' do
    let(:params) { {} }
    let(:request) { post :create, params: params }

    context 'with valid params' do
      let(:long_link) { 'https://www.google.com' }
      let(:params) { { long_link: long_link, user_id: 1 } }

      it 'returns a 201' do
        request
        expect(response).to have_http_status(:created)
      end

      it 'creates a short_link' do
        expect { request }.to change(ShortLink, :count).by(1)
      end

      it 'returns payload' do
        request
        expect(JSON.parse(response.body))
          .to eq('long_link' => long_link, 'short_link' => "http://test.host/#{ShortLink.last.encoded_id}")
      end
    end

    context 'with duplicate long_link' do
      let(:long_link) { 'https://www.google.com' }
      let!(:short_link) { create(:short_link, long_link: long_link, user_id: 1) }
      let(:params) { { long_link: long_link, user_id: 1 } }

      it 'returns a 201' do
        request
        expect(response).to have_http_status(:created)
      end

      it 'does not create a short_link' do
        expect { request }.to change(ShortLink, :count).by(0)
      end

      it 'returns payload' do
        request
        expect(JSON.parse(response.body))
          .to eq('long_link' => long_link, 'short_link' => "http://test.host/#{short_link.encoded_id}")
      end
    end

    context 'with invalid params' do
      context 'missing long_link' do
        let(:params) { { long_link: nil, user_id: 1 } }

        it 'returns a 422' do
          request
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'returns error' do
          request
          expect(JSON.parse(response.body)).to eq('long_link' => ["can't be blank", 'is invalid'])
        end
      end

      context 'invalid url' do
        let(:params) { { long_link: 'invalid', user_id: 1 } }

        it 'returns a 422' do
          request
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'returns error' do
          request
          expect(JSON.parse(response.body)).to eq('long_link' => ['is invalid'])
        end
      end
    end
  end

  describe 'GET #analytics' do
    let(:long_link) { 'https://www.google.com.br' }
    let!(:short_link) { create(:short_link, long_link: long_link, user_id: 1) }
    let(:request_show) { get :show, params: { id: short_link.encoded_id, user_id: 1 } }
    let(:request_show2) { get :show, params: { id: short_link.encoded_id, user_id: 1 } }

    let(:params) { { id: short_link.encoded_id } }
    let(:fail_params) { { id: "abc" } }
    let(:request) { get :analytics, params: params }
    let(:fail_request) { get :analytics, params: fail_params }

    context 'with valid params' do
      it 'return payload' do
        request_show
        request_show2
        request

        payload = JSON.parse(response.body)
        expect(payload["long_link"]).to eq(long_link)
        expect(payload["short_link"]).to eq("http://test.host/#{ShortLink.last.encoded_id}")
        expect(payload["accesses"]).to eq(2)
      end
    end

    context 'with invalid params' do
      it 'raise 404' do
        fail_request
        
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
