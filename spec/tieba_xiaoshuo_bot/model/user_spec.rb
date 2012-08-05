# coding: utf-8
require 'spec_helper'

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

      specify {@user.should have(4).fictions}

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

      it "active? and deactive? should be right" do
        active = DB[:users].select(:active).where(:account => "crhan123@gmail.com").first[:active]
        active.should == @user.active?
        active.should_not == @user.deactive?
      end

      describe "#mode" do
        it "should return the right mode" do
          @user.mode.should == "cron" if @user.active?
          @user.mode.should == "check" if @user.deactive?
        end
      end

      describe "#sub_fiction" do
        context "with a new fiction" do
          it "a new fiction created and subscribed" do
            old_count = Fiction.count
            result = @user.sub_fiction("哈哈")
            new_count = Fiction.count
            new_count.should_not == old_count
            result.should == true
            result2 = @user.sub_fiction("哈哈")
            result2.should == true
            Fiction.count.should == new_count
            @user.send(:get_sub, "哈哈").should_not be_nil
          end
        end
        context "with an old fiction" do
          it "do no change" do
            old_count = Fiction.count
            result = @user.sub_fiction("神印王座")
            new_count = Fiction.count
            new_count.should == old_count
            result.should be_true
          end
        end
        context "with an unsubed fiction" do
          it "change the subscribed status" do
            expect {@user.sub_fiction("遮天")}.to change{@user.send(:get_sub,"遮天")}
          end
        end
      end

      describe "#unsub_fiction" do
        context "with a new fiction" do
          specify {@user.unsub_fiction("哈哈").should be_false}
        end
        context "with a unsubed fiction" do
          specify {@user.unsub_fiction("遮天").should be_false}
        end
        context "with a subed fiction" do
          specify {@user.unsub_fiction("神印王座").should be_true}
        end
      end

      describe "#active_fictions" do
        specify {@user.should have(3).active_fictions}
      end

      describe "#switch_mode" do
        it "should change active status" do
          expect {@user.switch_mode}.to change{@user.active}
        end
      end
    end

    it %|raise "Sequel::ValidationFailed" when create second account named "crhan123@gmail.com"| do
      expect {
        User.create(:account => "crhan123@gmail.com")
      }.to raise_error(Sequel::ValidationFailed)
    end
  end
end
