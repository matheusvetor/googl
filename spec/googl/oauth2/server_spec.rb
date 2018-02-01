require 'spec_helper'

describe Googl::OAuth2::Server do
  before :each do
    fake_urls? true
  end

  subject do
    Googl::OAuth2.server('438834493660.apps.googleusercontent.com', '8i4iJJkFTukWhNpxTU1b2Zhi', 'http://gooogl.heroku.com/back')
  end

  describe '#initialize' do
    it 'should assign client_id' do
      subject.client_id.should == '438834493660.apps.googleusercontent.com'
    end

    it 'should assign client_secret' do
      subject.client_secret.should == '8i4iJJkFTukWhNpxTU1b2Zhi'
    end

    it 'should assign redirect_uri' do
      subject.redirect_uri.should == 'http://gooogl.heroku.com/back'
    end
  end

  describe '#authorize_url' do
    it { subject.should respond_to(:authorize_url) }
    it 'should return url for authorize' do
      subject.authorize_url.should == 'https://accounts.google.com/o/oauth2/auth?client_id=438834493660.apps.googleusercontent.com&redirect_uri=http://gooogl.heroku.com/back&scope=https://www.googleapis.com/auth/urlshortener&response_type=code'
    end

    it 'should include the client_id' do
      subject.authorize_url.should be_include('client_id=438834493660.apps.googleusercontent.com')
    end

    it 'should include the redirect_uri' do
      subject.authorize_url.should be_include('redirect_uri=http://gooogl.heroku.com/back')
    end

    it 'should include the scope' do
      subject.authorize_url.should be_include('scope=https://www.googleapis.com/auth/urlshortener')
    end

    it 'should include the response_type' do
      subject.authorize_url.should be_include('response_type=code')
    end
  end

  describe '#request_access_token' do
    it { subject.should respond_to(:request_access_token) }

    context 'with valid code' do
      let(:server) { subject.request_access_token('4/z43CZpNmqd0IO3dR1Y_ouase13CH') }

      it 'should return a access_token' do
        server.access_token.should == '1/9eNgoHDXi-1u1fDzZ2wLLGATiaQZnWPB51nTvo8n9Sw'
      end

      it 'should return a refresh_token' do
        server.refresh_token.should == '1/gvmLC5XlU0qRPIBR3mt7OBBfEoTKB6i2T-Gu4dBDupw'
      end

      it 'should return a expires_in' do
        server.expires_in.should == 3600
      end
    end

    context 'with invalid code' do
      it 'should raise error' do
        lambda {  subject.request_access_token('my_invalid_code')  }.should raise_error(/400 invalid_token/)
      end
      it 'should raise Invalid Credentials on 401 response' do
        lambda {  subject.request_access_token('4/JvkEhCtr7tv1A60ENmubQT-cosRl')  }.should raise_error(/401 Invalid Credentials/)
      end
    end
  end

  describe '#expires_at' do
    before do
      @now = Time.now
      Timecop.freeze(@now)
    end

    let(:server) { subject.request_access_token('4/z43CZpNmqd0IO3dR1Y_ouase13CH') }

    it 'should be a time representation of #expires_in' do
      server.expires_at.should == (@now + 3600)
    end

    after do
      Timecop.return
    end
  end

  describe '#expires?' do
    before :each do
      Timecop.freeze(DateTime.parse('2011-04-23 15:30:00'))
      subject.request_access_token('4/z43CZpNmqd0IO3dR1Y_ouase13CH')
    end

    it 'should be true if access token expires' do
      Timecop.freeze(DateTime.parse('2011-04-23 18:30:00')) do
        subject.expires?.should be true
      end
    end

    it 'should be false if access token not expires' do
      subject.expires?.should be false
    end

    after do
      Timecop.return
    end
  end

  describe '#authorized?' do
    it 'should return false if client is not authorized' do
      subject.authorized?.should be false
    end

    let(:server) { subject.request_access_token('4/z43CZpNmqd0IO3dR1Y_ouase13CH') }

    it 'should return true if client is authorized' do
      server.authorized?.should be true
    end
  end

  context 'when gets a user history of shortened' do
    it { subject.should respond_to(:history) }

    it 'should not return when client not authorized' do
      subject.history.should be_nil
    end

    context 'if authorized' do
      let(:server) { subject.request_access_token('4/z43CZpNmqd0IO3dR1Y_ouase13CH') }
      let(:history) { server.history }

      it { history.should respond_to(:total_items) }
      it { history.should respond_to(:items_per_page) }
      it { history.should respond_to(:items) }
    end
  end
end
