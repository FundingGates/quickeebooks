require 'spec_helper'

describe "Quickeebooks::Windows::Model::Invoice" do
  it "can parse invoice from XML" do
    xml = onlineFixture("invoice.xml")
    invoice = Quickeebooks::Windows::Model::Invoice.from_xml(xml)
    invoice.header.balance.should == 0
    invoice.header.sales_term_id.value.should == "3"
    invoice.id.value.should == "13"
    invoice.line_items.count.should == 1
    invoice.line_items.first.unit_price.should == 225
  end

  it "does not set id if it is not present" do
    xml = <<EOT
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Invoice xmlns="http://www.intuit.com/sb/cdm/v2" xmlns:qbp="http://www.intuit.com/sb/cdm/qbopayroll/v1" xmlns:qbo="http://www.intuit.com/sb/cdm/qbo">
  <Header>
  </Header>
</Invoice>
EOT
    invoice = Quickeebooks::Windows::Model::Invoice.from_xml(xml)
    invoice.id.should eq nil
  end

  it "does not set header.sales_term_id if it is not present" do
    xml = <<EOT
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Invoice xmlns="http://www.intuit.com/sb/cdm/v2" xmlns:qbp="http://www.intuit.com/sb/cdm/qbopayroll/v1" xmlns:qbo="http://www.intuit.com/sb/cdm/qbo">
  <Header>
  </Header>
</Invoice>
EOT
    invoice = Quickeebooks::Windows::Model::Invoice.from_xml(xml)
    invoice.header.sales_term_id.should eq nil
  end
end
