require 'spec_helper'
require 'fakefs/spec_helpers'

RSpec.describe 'Persistence' do
  include FakeFS::SpecHelpers

  Persistence = Standards::Persistence
  Structure   = Standards::Structure
  Standard    = Standards::Standard

  let :structure do
    Structure.new [
      Standard.new(id:       123,
                   standard: 'my standard',
                   tags:     ['tag1', 'tag2'])
    ]
  end

  let(:filename) { "mystructure" }

  def dump(filename, structure)
    Persistence.dump filename, structure
  end

  describe 'dumping' do
    it 'dumps the structure to the file in JSON format' do
      dump(filename, structure)
      actual_raw_structure = JSON.load(File.read filename)
      expected_raw_structure = JSON.load '{"standards": [{"id":123, "standard":"my standard", "tags":["tag1", "tag2"]}]}'
      expect(actual_raw_structure).to eq expected_raw_structure
    end

    it 'overwrites the existing contents of the file' do
      File.write(filename, "content")
      dump filename, structure
      body = File.read filename
      expect(body).to_not include "content"
      expect(body).to include '"standards":'
    end

    it 'raises an error when attempting to persist a structure with a standard that does not have an id' do
      s = Structure.new
      s.standards << Standard.new(standard: "a")
      expect { dump filename, s }.to raise_error /\bid\b/
    end

    it 'raises an error when attempting to persist a structure with a standard that is empty' do
      s = Structure.new
      s.add_standard id: 1
      expect { dump filename, s }.to raise_error /\bstandard\b/
    end

    it 'creates the path to the file if the path DNE' do
      dump '/a/b/c', structure
      body = File.read '/a/b/c'
      expect(body).to include '"standards":'
    end
  end

  describe 'loading' do
    def load(filename)
      Persistence.load filename
    end

    it 'loads the JSON structure from the file and returns a Structure object' do
      dump(filename, structure)
      new_structure = load(filename)
      expect(new_structure.to_hash).to eq({standards: [{id: 123, standard: "my standard", tags: ["tag1", "tag2"]}]})
      expect(new_structure).to_not equal structure
    end

    it 'returns an empty Structure object when the file DNE' do
      expect(File.exist? filename).to eq false
      expect(load(filename).to_hash).to eq({standards: []})
    end
  end

  describe 'deleting' do
    def delete(filename)
      Persistence.delete filename
    end

    it 'deletes the file if it exists' do
      File.write filename, 'some body'
      delete filename
      expect(File.exist? filename).to eq false
    end

    it 'does nothing if the file DNE' do
      expect(File.exist? filename).to eq false
      expect { delete filename }.to_not raise_error
      expect(File.exist? filename).to eq false
    end
  end
end
