require "spec_helper"

describe Statesman::Callback do
  let(:cb_lambda) { -> { } }
  let(:callback) do
    Statesman::Callback.new(from: nil, to: nil, callback: cb_lambda)
  end

  describe "#initialize" do
    context "with no callback" do
      let(:cb_lambda) { nil }

      it "raises an error" do
        expect { callback }.to raise_error(Statesman::InvalidCallbackError)
      end
    end
  end

  describe "#call" do
    let(:spy) { double.as_null_object }
    let(:cb_lambda) { -> { spy.call } }

    it "delegates to callback" do
      callback.call
      expect(spy).to have_received(:call)
    end
  end

  describe "#applies_to" do
    let(:callback) do
      Statesman::Callback.new(from: :x, to: :y, callback: cb_lambda)
    end
    subject { callback.applies_to?(from: from, to: to) }

    context "with any from value" do
      let(:from) { nil }

      context "and an allowed to value" do
        let(:to) { :y }
        it { should be_true }
      end

      context "and a disallowed to value" do
        let(:to) { :a }
        it { should be_false }
      end
    end

    context "with any to value" do
      let(:to) { nil }

      context "and an allowed 'from' value" do
        let(:from) { :x }
        it { should be_true }
      end

      context "and a disallowed 'from' value" do
        let(:from) { :a }
        it { should be_false }
      end
    end

    context "with allowed 'form' and 'to' values" do
      let(:from) { :x }
      let(:to) { :y }
      it { should be_true }
    end

    context "with disallowed 'form' and 'to' values" do
      let(:from) { :a }
      let(:to) { :b }
      it { should be_false }
    end
  end
end