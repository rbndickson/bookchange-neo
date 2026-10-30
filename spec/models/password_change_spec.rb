require 'rails_helper'

describe PasswordChange, type: :model do
  let(:alice) { Fabricate(:alice) }

  def password_change(current_password: 'password', new_password: 'newpassword',
                      new_password_confirmation: new_password)
    described_class.new(user: alice, current_password: current_password, new_password: new_password,
                        new_password_confirmation: new_password_confirmation)
  end

  def errors_on(attribute, **attributes)
    change = password_change(**attributes)
    change.valid?
    change.errors[attribute]
  end

  describe 'current password' do
    it 'shows only the blank error when blank' do
      expect(errors_on(:current_password, current_password: '')).to eq(["can't be blank"])
    end

    it 'is incorrect when wrong' do
      expect(errors_on(:current_password, current_password: 'wrong password')).to eq(['is incorrect'])
    end
  end

  describe 'new password' do
    it 'is blank and too short when blank, as on Sign Up' do
      expect(errors_on(:new_password, new_password: ''))
        .to eq(["can't be blank", 'is too short (minimum is 8 characters)'])
    end

    it 'is at least 8 characters' do
      expect(errors_on(:new_password, new_password: 'a' * 7)).to eq(['is too short (minimum is 8 characters)'])
    end

    it 'is at most 72 characters' do
      expect(errors_on(:new_password, new_password: 'a' * 73)).to eq(['is too long (maximum is 72 characters)'])
    end

    it 'is at most 72 bytes' do
      expect(errors_on(:new_password, new_password: '😀' * 19)).to eq(['is too long (maximum is 72 characters)'])
    end
  end

  describe 'new password confirmation' do
    it 'must match the new password' do
      expect(errors_on(:new_password_confirmation, new_password_confirmation: 'something else'))
        .to eq(["doesn't match New Password"])
    end

    it 'is needed, and does not match when blank, as on Sign Up' do
      expect(errors_on(:new_password_confirmation, new_password_confirmation: ''))
        .to eq(["doesn't match New Password", "can't be blank"])
    end
  end

  describe 'full error messages' do
    it 'names the fields as labelled' do
      change = password_change(new_password_confirmation: 'something else')
      change.valid?
      expect(change.errors.full_messages).to eq(["Confirm New Password doesn't match New Password"])
    end
  end

  describe '#save' do
    it 'changes the password when valid' do
      expect(password_change.save).to be(true)
      expect(alice.reload.authenticate('newpassword')).to eq(alice)
    end

    it 'accepts the current password as the new one' do
      expect(password_change(new_password: 'password').save).to be(true)
    end

    it 'leaves the password unchanged when invalid' do
      expect(password_change(current_password: 'wrong password').save).to be(false)
      expect(alice.reload.authenticate('password')).to eq(alice)
    end
  end
end
