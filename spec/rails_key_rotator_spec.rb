# frozen_string_literal: true

RSpec.describe RailsKeyRotator do
  let(:old_key) { ActiveSupport::EncryptedConfiguration.generate_key }
  let(:new_key) { ActiveSupport::EncryptedConfiguration.generate_key }
  let(:credentials_file_path) { Tempfile.new("credentials.yml.enc").path }
  let(:credentials_key_path) { Tempfile.new("master.key").path }
  let(:credentials) {
    ActiveSupport::EncryptedConfiguration.new(
      config_path: credentials_file_path,
      key_path: credentials_key_path,
      env_key: "RAILS_MASTER_KEY",
      raise_if_missing_key: true
    )
  }

  it "has a version number" do
    expect(RailsKeyRotator::VERSION).not_to be nil
  end

  describe ".credentials_path" do
    it "returns a value" do
      expect(described_class.credentials_path).to eql("/app/config/credentials/test.yml.enc")
    end
  end

  describe ".key_path" do
    it "returns a value" do
      expect(described_class.key_path).to eql("/app/config/credentials/test.key")
    end
  end

  describe ".rotated?" do
    before do
      allow(described_class).to receive(:credentials_path).and_return(credentials_file_path)
      allow(described_class).to receive(:key_path).and_return(credentials_key_path)
    end

    after do
      ENV["RAILS_MASTER_KEY"] = nil
      ENV["RAILS_MASTER_KEY_NEW"] = nil
      FileUtils.rm_rf credentials_file_path
      FileUtils.rm_rf credentials_key_path
    end

    context "When 'RAILS_MASTER_KEY' is not set" do
      before do
        File.write(credentials_key_path, old_key)
        credentials.write({something: {good: true, bad: false}}.to_yaml)
      end

      it "does silently nothing" do
        expect { described_class.rotated? }.to output("").to_stderr
      end
    end

    context "When 'RAILS_MASTER_KEY_NEW' is not set" do
      before do
        ENV["RAILS_MASTER_KEY"] = old_key
        credentials.write({something: {good: true, bad: false}}.to_yaml)
      end

      it "does silently nothing" do
        expect { described_class.rotated? }.to output("").to_stderr
      end
    end

    context "With 'RAILS_MASTER_KEY_NEW' set to an value" do
      before do
        ENV["RAILS_MASTER_KEY"] = old_key
        ENV["RAILS_MASTER_KEY_NEW"] = new_key
        credentials.write({something: {good: true, bad: false}}.to_yaml)
      end

      it "file encrypted w/ old key" do
        expect { described_class.rotated? }.to output(/KeyRotator: Using OLD key for test env/).to_stderr
        expect(ENV["RAILS_MASTER_KEY"]).not_to eql(new_key)
      end

      context "file encrypted w/ new key" do
        let(:credentials) {
          ActiveSupport::EncryptedConfiguration.new(
            config_path: credentials_file_path,
            key_path: credentials_key_path,
            env_key: "RAILS_MASTER_KEY_NEW",
            raise_if_missing_key: true
          )
        }

        it "Uses new key" do
          expect(ENV["RAILS_MASTER_KEY_NEW"]).to eql(new_key)
          expect { described_class.rotated? }.to output(/KeyRotator: Using NEW key for test env/).to_stderr
          expect(ENV["RAILS_MASTER_KEY"]).to eql(new_key)
        end
      end
    end
  end

  describe ".rotate" do
    let(:credentials_file_path) { Tempfile.new("credentials.yml.enc").path }
    let(:credentials_key_path) { Tempfile.new("master.key").path }

    subject { described_class.rotate }

    context "no credentails available" do
      it "raises an error" do
        expect { subject }.to raise_error(ActiveSupport::EncryptedFile::MissingKeyError)
      end
    end

    context "credentials available" do
      before do
        allow(described_class).to receive(:credentials_path).and_return(credentials_file_path)
        allow(described_class).to receive(:key_path).and_return(credentials_key_path)
        allow(Time).to receive(:new).and_return(Time.at(1697359415)) # 2023-10-15-104335

        File.write(credentials_key_path, old_key)
        credentials.write({something: {good: true, bad: false}}.to_yaml)
      end

      it "does backup when files exists" do
        allow(FileUtils).to receive(:mv)
        allow(File).to receive(:write)

        subject

        expect(FileUtils).to have_received(:mv).with(credentials_key_path, "#{credentials_key_path}.bak-2023-10-15-084335").once
        expect(FileUtils).to have_received(:mv).with(credentials_file_path, "#{credentials_file_path}.bak-2023-10-15-084335").once
        expect(File).to have_received(:write).with(credentials_key_path, described_class.send(:new_key)).once
      end
    end
  end
end
