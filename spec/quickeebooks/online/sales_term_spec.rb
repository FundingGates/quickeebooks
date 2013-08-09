require 'spec_helper'

describe "Quickeebooks::Online::Model::SalesTerm" do
  it "can parse sales term from XML" do
    xml = onlineFixture("sales_term.xml")
    sales_term = Quickeebooks::Online::Model::SalesTerm.from_xml(xml)

    sales_term.id.value.should == '3'
    sales_term.sync_token.should == 0
    sales_term.meta_data.create_time.should == Time.parse('2013-01-17T19:04:19-08:00')
    sales_term.meta_data.last_updated_time.should == Time.parse('2013-01-17T19:04:19-08:00')
    sales_term.name.should == "Net 30"
  end
end
