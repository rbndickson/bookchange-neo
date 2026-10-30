require 'rails_helper'

describe User, type: :model do
  subject { Fabricate.build(:user) }

  let(:alice) { Fabricate(:alice) }

  it { is_expected.to have_secure_password }

  it { is_expected.to validate_presence_of(:email) }
  it { is_expected.to validate_length_of(:email).is_at_most(254) }
  it { is_expected.to allow_value('alice@example.com').for(:email) }
  it { is_expected.to allow_value("#{"a" * 242}@example.com").for(:email) }
  it { is_expected.not_to allow_value('alice').for(:email).with_message('is invalid') }
  it { is_expected.to validate_uniqueness_of(:email).ignoring_case_sensitivity.with_message('cannot be used') }
  it { is_expected.to normalize(:email).from(' Alice@Example.com ').to('alice@example.com') }

  it { is_expected.to validate_presence_of(:username) }
  it { is_expected.to validate_length_of(:username).is_at_least(2).is_at_most(20) }
  it { is_expected.to validate_uniqueness_of(:username).case_insensitive }
  it { is_expected.to normalize(:username).from(' Alice ').to('Alice') }

  it { is_expected.to validate_presence_of(:password) }
  it { is_expected.to validate_length_of(:password).is_at_least(8) }
  it { is_expected.to validate_confirmation_of(:password) }
  it { is_expected.to validate_presence_of(:password_confirmation) }

  def errors_on(attribute, **attributes)
    user = Fabricate.build(:user, **attributes)
    user.valid?
    user.errors[attribute]
  end

  describe 'email' do
    it 'shows only the blank error when blank' do
      expect(errors_on(:email, email: '')).to eq(["can't be blank"])
    end

    it 'is unique ignoring letter case and surrounding spaces' do
      alice
      expect(errors_on(:email, email: ' Alice@Example.com ')).to eq(['cannot be used'])
    end
  end

  describe 'username' do
    it 'shows only the blank error when blank' do
      expect(errors_on(:username, username: '')).to eq(["can't be blank"])
    end

    it 'shows only the blank error when only spaces' do
      expect(errors_on(:username, username: '   ')).to eq(["can't be blank"])
    end

    it 'is unique ignoring surrounding spaces' do
      alice
      expect(errors_on(:username, username: ' alice ')).to eq(['has already been taken'])
    end

    it 'counts its length without surrounding spaces' do
      expect(errors_on(:username, username: ' a ')).to eq(['is too short (minimum is 2 characters)'])
    end
  end

  describe 'password' do
    it 'allows 72 characters' do
      expect(errors_on(:password, password: 'a' * 72, password_confirmation: 'a' * 72)).to be_empty
    end

    it 'is at most 72 characters' do
      expect(errors_on(:password, password: 'a' * 73, password_confirmation: 'a' * 73))
        .to eq(['is too long (maximum is 72 characters)'])
    end

    it 'is at most 72 bytes' do
      password = '😀' * 19
      expect(errors_on(:password, password: password, password_confirmation: password))
        .to eq(['is too long (maximum is 72 characters)'])
    end

    context 'when the user is saved' do
      let(:saved_alice) { described_class.find(alice.id) }

      it 'is not needed to update other fields' do
        expect(saved_alice.update(username: 'alice2')).to be(true)
      end

      it 'is at least 8 characters when a new one is set' do
        saved_alice.update(password: 'short', password_confirmation: 'short')
        expect(saved_alice.errors[:password]).to eq(['is too short (minimum is 8 characters)'])
      end

      it 'needs a confirmation when a new one is set' do
        saved_alice.update(password: 'newpassword')
        expect(saved_alice.errors[:password_confirmation]).to eq(["can't be blank"])
      end
    end
  end

  describe 'full error messages' do
    it 'names the field before each message' do
      alice
      user = Fabricate.build(:user, email: 'alice@example.com', password_confirmation: '')
      user.valid?
      expect(user.errors.full_messages).to include('Email cannot be used', "Confirm Password can't be blank")
    end
  end

  describe '.authenticate_by' do
    before { alice }

    it 'finds the user ignoring letter case and surrounding spaces in the email' do
      expect(described_class.authenticate_by(email: ' ALICE@example.com ', password: 'password')).to eq(alice)
    end

    it 'returns nil for a wrong password' do
      expect(described_class.authenticate_by(email: 'alice@example.com', password: 'wrong password')).to be_nil
    end

    it 'returns nil for an unknown email' do
      expect(described_class.authenticate_by(email: 'bob@example.com', password: 'password')).to be_nil
    end
  end

  describe 'session token' do
    let(:alices_token) { alice.generate_token_for(:session) }

    it 'finds the user' do
      expect(described_class.find_by_token_for(:session, alices_token)).to eq(alice)
    end

    context 'when the password has changed' do
      before do
        alices_token
        alice.update(password: 'newpassword', password_confirmation: 'newpassword')
      end

      it 'does not find the user with a token made before' do
        expect(described_class.find_by_token_for(:session, alices_token)).to be_nil
      end

      it 'finds the user with a new token' do
        expect(described_class.find_by_token_for(:session, alice.generate_token_for(:session))).to eq(alice)
      end
    end
  end
end
