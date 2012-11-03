# -*- encoding : utf-8 -*-
require 'spec_helper'

describe 'validate FactoryGirl factories' do
  FactoryGirl.factories.each do |factory|
    context "with factory for :#{factory.name}" do
      subject { FactoryGirl.build(factory.name) }

      it "is valid" do
        subject.valid?.should be, subject.errors.full_messages
      end
    end
  end
end
