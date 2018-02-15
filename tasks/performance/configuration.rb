require_relative '../helpers/trie'
require_relative '../helpers/gc'
require_relative 'sub_tasks'
require_relative 'reporters'

module Performance
  class Configuration
    include Helpers::GC

    def get type, method
      type ||= 'all'
      method ||= 'all'

      if type == 'all'
        get_all_types method
      elsif method == 'all'
        get_all_methods type
      else
        tasks[type][method]
      end
    end

    def get_all_types method
      lambda do |output|
        tasks.keys.each do |type|
          output.puts
          output.puts "Running #{type} tasks..."
          get(type, method).call output
        end
      end
    end

    def get_all_methods type
      lambda do |output|
        tasks[type].each do |method, task|
          task.call output
        end
      end
    end

    def tasks
      {
        'benchmark' => benchmark_tasks,
        'call_tree' => call_tree_tasks,
        'memory' => memory_tasks,
        'flamegraph' => flamegraph_tasks,
      }
    end

    def banner output, title
      output.puts
      output.puts "==> #{title}"
    end

    def benchmark_tasks
      sub_tasks Performance::Reporters::Benchmark
    end

    def call_tree_tasks
      sub_tasks Performance::Reporters::CallTreeProfile
    end

    def memory_tasks
      sub_tasks Performance::Reporters::MemoryProfile, 1 do
        with_gc_stats 'garbage collection' do
          ::GC.start
        end
      end
    end

    def flamegraph_tasks
      sub_tasks Performance::Reporters::Flamegraph, 1
    end

    def sub_tasks reporter_class, iterations = nil
      sub_tasks = {}

      sub_tasks_creators.each do |name, creator|
        task = creator.call iterations

        sub_tasks[name] = lambda do |output|
          banner output, task.description
          task.execute reporter_class
          yield if block_given?
        end
      end

      sub_tasks
    end

    def sub_tasks_creators
      {
        'creation' => creation_task_creator,
        'compression' => compression_task_creator,
        'serialization:raw' => serialization_raw_task_creator,
        'serialization:compressed' => serialization_compressed_task_creator,
        'lookups:word:raw' => lookups_word_raw_task_creator,
        'lookups:word:compressed' => lookups_word_compressed_task_creator,
        'lookups:partial_word:raw' => lookups_partial_word_raw_task_creator,
        'lookups:partial_word:compressed' => lookups_partial_word_compressed_task_creator,
        'lookups:scan:raw' => lookups_scan_raw_task_creator,
        'lookups:scan:compressed' => lookups_scan_compressed_task_creator,
        'lookups:words_within:raw' => lookups_words_within_raw_task_creator,
        'lookups:words_within:compressed' => lookups_words_within_compressed_task_creator,
      }
    end

    def creation_task_creator
      lambda do |iterations|
        iterations ||= 5
        Performance::SubTasks::Creation.new iterations
      end
    end

    def compression_task_creator
      lambda do |iterations|
        iterations ||= 5
        Performance::SubTasks::Compression.new iterations
      end
    end

    def serialization_raw_task_creator
      lambda do |iterations|
        iterations ||= 5
        Performance::SubTasks::Serialization::Raw.new iterations
      end
    end

    def serialization_compressed_task_creator
      lambda do |iterations|
        iterations ||= 5
        Performance::SubTasks::Serialization::Compressed.new iterations
      end
    end

    def lookups_word_raw_task_creator
      lambda do |iterations|
        iterations ||= 200_000
        Performance::SubTasks::Lookups::Word::Raw.new iterations
      end
    end

    def lookups_word_compressed_task_creator
      lambda do |iterations|
        iterations ||= 200_000
        Performance::SubTasks::Lookups::Word::Compressed.new iterations
      end
    end

    def lookups_partial_word_raw_task_creator
      lambda do |iterations|
        iterations ||= 200_000
        Performance::SubTasks::Lookups::PartialWord::Raw.new iterations
      end
    end

    def lookups_partial_word_compressed_task_creator
      lambda do |iterations|
        iterations ||= 200_000
        Performance::SubTasks::Lookups::PartialWord::Compressed.new iterations
      end
    end

    def lookups_scan_raw_task_creator
      lambda do |iterations|
        if iterations.nil? || iterations == 200_000
          Performance::SubTasks::Lookups::Scan::Raw.new
        else
          Performance::SubTasks::Lookups::Scan::Raw.new(
            hi: iterations,
            help: iterations,
            beautiful: iterations,
            impressionism: iterations,
            anthropological: iterations,
          )
        end
      end
    end

    def lookups_scan_compressed_task_creator iterations = 200_000
      lambda do |iterations|
        if iterations.nil? || iterations == 200_000
          Performance::SubTasks::Lookups::Scan::Compressed.new
        else
          Performance::SubTasks::Lookups::Scan::Compressed.new(
            hi: iterations,
            help: iterations,
            beautiful: iterations,
            impressionism: iterations,
            anthropological: iterations,
          )
        end
      end
    end

    def lookups_words_within_raw_task_creator iterations = 100_000
      lambda do |iterations|
        iterations ||= 100_000
        Performance::SubTasks::Lookups::WordsWithin::Raw.new iterations
      end
    end

    def lookups_words_within_compressed_task_creator iterations = 100_000
      lambda do |iterations|
        iterations ||= 100_000
        Performance::SubTasks::Lookups::WordsWithin::Compressed.new iterations
      end
    end
  end
end
