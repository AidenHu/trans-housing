require 'rails_helper'

RSpec.describe User, type: :model do

  it "has a valid fabricator" do
    expect(Fabricate(:user)).to be_valid
  end

  describe "creating an account" do

    describe "given valid credentials" do

      describe "for contact information" do
        
        it "is valid with just one contact method: an email address" do
          expect(Fabricate.build(:user, contact: Fabricate.build(:email_only))).to be_valid
        end

        it "is valid with just one contact method: a phone number" do
          expect(Fabricate.build(:user, contact: Fabricate.build(:phone_only))).to be_valid
        end

        it "converts the email address to all lowercase" do
          user = Fabricate(:user, contact: Fabricate.build(:contact, email: "TEST@TEST.com"))
          expect(user.contact.email).to eq("test@test.com")
        end
      end

      describe "for gender information" do
        context "as a nonbinary trans person" do
          it "is valid with custom pronouns" do
            expect(Fabricate.build(:nonbinary_user)).to be_valid
          end
          it "is valid without custom pronouns" do
            expect(Fabricate.build(:user, gender: Fabricate.build(:nonbinary_gender, cp:false, they: nil, their: nil, them: nil))).to be_valid
          end
        end
      end
    end

    describe "given invalid credentials" do 

      it "is invalid without a name" do
        expect(Fabricate.build(:user, name: nil)).to_not be_valid
      end

      describe "for contact information" do
        it "is invalid with no contact profile" do
          expect(Fabricate.build(:user, contact: nil)).to_not be_valid
        end

        it "is invalid without at least one contact method" do
          expect(Fabricate.build(:user, contact: Fabricate.build(:contact, email: nil, phone: nil))).to_not be_valid
        end
      end

      describe "for gender information" do
         it "is invalid without a gender" do
          expect(Fabricate.build(:user, gender: nil)).to_not be_valid
        end
        it "is invalid without specifying trans status" do
          expect(Fabricate.build(:user, gender: Fabricate.build(:binary_gender, trans: nil))).to_not be_valid
        end

        context "as a cis person" do
          it "is invalid if claiming need for custom pronouns" do
            expect(Fabricate.build(:user, gender: Fabricate.build(:binary_gender, cp:true))).to_not be_valid
          end

          it "is invalid if setting custom pronouns of any tense (they,them,their)" do
            expect(Fabricate.build(:user, gender: Fabricate.build(:binary_gender, they:"They"))).to_not be_valid
            expect(Fabricate.build(:user, gender: Fabricate.build(:binary_gender, them:"Them"))).to_not be_valid
            expect(Fabricate.build(:user, gender: Fabricate.build(:binary_gender, their:"Their"))).to_not be_valid
          end
        end

        context "as a nonbinary trans person" do
          it "is invalid if claims need for custom pronouns but does not specify them all" do
            expect(Fabricate.build(:nonbinary_user, gender: Fabricate.build(:custom_pronoun_gender, they: nil))).to_not be_valid
            expect(Fabricate.build(:nonbinary_user, gender: Fabricate.build(:custom_pronoun_gender, them: nil))).to_not be_valid
            expect(Fabricate.build(:nonbinary_user, gender: Fabricate.build(:custom_pronoun_gender, their: nil))).to_not be_valid
          end
        end
      end
     
      it "is invalid if signing up with an existing email" do
        Fabricate(:user, contact: Fabricate.build(:contact, email: "TEST@TEST.com"))
        expect(Fabricate.build(:user, contact: Fabricate.build(:contact, email: "TEST@TEST.com"))).to_not be_valid
      end
      it "is invalid if signing up with an existing phone number" do
        Fabricate(:user, contact: Fabricate.build(:contact, phone: "111-111-1111"))
        expect(Fabricate.build(:user, contact: Fabricate.build(:contact, phone: "111-111-1111"))).to_not be_valid
      end
    end
  end

  describe "deleting an account" do
    it "destroys contact information" do
      user = Fabricate(:user)
      expect { user.destroy }.to change {Contact.count}.by(-1)
    end
    it "destroys location information" do
      user = Fabricate(:user)
      expect { user.destroy }.to change {Location.count}.by(-1)
    end
  end

  describe ".provider?" do
    it "returns true if user is a provider and false if a seeker" do
      expect(Fabricate(:provider).provider?).to eq true
      expect(Fabricate(:seeker).provider?).to eq false
    end
  end
  describe ".seeker?" do
    it "returns true if user is a seeker and false if a provider" do
      expect(Fabricate(:seeker).seeker?).to eq true
      expect(Fabricate(:provider).seeker?).to eq false
    end
  end
end