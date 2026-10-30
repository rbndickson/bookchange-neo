require 'rails_helper'

describe User do
  let(:alice) { Fabricate(:alice) }

  def errors_on(attribute, **attributes)
    user = Fabricate.build(:user, **attributes)
    user.valid?
    user.errors[attribute]
  end

  describe 'email' do
    it 'is required' do
      expect(errors_on(:email, email: '')).to eq(["can't be blank"])
    end

    it 'must be a valid email' do
      expect(errors_on(:email, email: 'alice')).to include('is invalid')
    end

    it 'is at most 254 characters' do
      email = "#{"a" * 243}@example.com"
      expect(errors_on(:email, email: email)).to include('is too long (maximum is 254 characters)')
    end

    it 'allows 254 characters' do
      email = "#{"a" * 242}@example.com"
      expect(errors_on(:email, email: email)).to be_empty
    end

    it 'is unique' do
      alice
      expect(errors_on(:email, email: 'alice@example.com')).to eq(['cannot be used'])
    end

    it 'is unique ignoring letter case and surrounding spaces' do
      alice
      expect(errors_on(:email, email: ' Alice@Example.com ')).to eq(['cannot be used'])
    end

    it 'is saved in lowercase without surrounding spaces' do
      user = Fabricate(:user, email: ' Alice@Example.com ')
      expect(user.reload.email).to eq('alice@example.com')
    end
  end

  describe 'username' do
    it 'is required' do
      expect(errors_on(:username, username: '')).to eq(["can't be blank"])
    end

    it 'is at least 2 characters' do
      expect(errors_on(:username, username: 'a')).to eq(['is too short (minimum is 2 characters)'])
    end

    it 'is at most 20 characters' do
      expect(errors_on(:username, username: 'a' * 21)).to eq(['is too long (maximum is 20 characters)'])
    end

    it 'allows 2 to 20 characters' do
      expect(errors_on(:username, username: 'ab')).to be_empty
      expect(errors_on(:username, username: 'a' * 20)).to be_empty
    end

    it 'is unique ignoring letter case' do
      alice
      expect(errors_on(:username, username: 'Alice')).to eq(['has already been taken'])
    end

    it 'is saved as typed' do
      user = Fabricate(:user, username: 'Alice')
      expect(user.reload.username).to eq('Alice')
    end
  end

  describe 'password' do
    it 'is required' do
      expect(errors_on(:password, password: '', password_confirmation: '')).to include("can't be blank")
    end

    it 'is at least 8 characters' do
      expect(errors_on(:password, password: 'a' * 7, password_confirmation: 'a' * 7))
        .to eq(['is too short (minimum is 8 characters)'])
    end

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
  end

  describe 'password confirmation' do
    it 'is required' do
      expect(errors_on(:password_confirmation, password_confirmation: '')).to include("can't be blank")
    end

    it 'must match the password' do
      expect(errors_on(:password_confirmation, password_confirmation: 'something else'))
        .to eq(["doesn't match Password"])
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
end
