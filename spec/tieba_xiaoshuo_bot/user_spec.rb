require 'spec_helper.rb'

module TiebaXiaoshuoBot
  describe User do
    describe "the first user" do
      def user_send_prepare fiction_id=nil
        last_count = @user.total_count
        msg, this_count = @user.send_prepare(:fiction_id => fiction_id)
        msg.should_not be_nil
        msg.should_not be_empty
        this_count.should_not be_nil
        this_count.should_not == 0
        @user.total_count.should == last_count + this_count
        msg_2, this_count_2 = @user.send_prepare(:fiction_id => fiction_id)
        msg_2.should be_empty
        this_count_2.should == 0
      end

      before(:each) do
        @user = User.first
      end

      around do |example|
        DB.transaction do
          example.run
          raise Sequel::Rollback
        end
      end

      it %|account should match "crhan123@gmail.com"| do
        @user.account.should match("crhan123@gmail.com")
      end

      it do
        @user.should have(4).fictions
      end

      describe "#sended" do
        it %|change by 1 when run with no arg| do
          expect { @user.sended }.to change{ @user.total_count }.by(1)
        end

        it %|change by 5 when run with 5| do
          expect { @user.sended 5 }.to change{ @user.total_count }.by(5)
        end
      end

      describe "#send_prepare" do
        it "prepare all the subscribed fictions" do
          user_send_prepare
        end

        it "prepare the Fiction[2]" do
          user_send_prepare 2
        end
      end

      it %|should have 3 active fictions|do
        @user.should have(3).active_fictions
      end

      it do
        pending "send the msg and change the total_count"
        expect {
          @user
        }
      end
    end

    it %|raise "Sequel::ValidationFailed" when create second account named "crhan123@gmail.com"| do
      expect {
        User.create(:account => "crhan123@gmail.com")
      }.to raise_error(Sequel::ValidationFailed)
    end
  end
end
