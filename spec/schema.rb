ActiveRecord::Schema.define version: 0 do
  create_table "afterparty_jobs", force: true do |t|
    t.text :job_dump
    t.string :queue
    t.datetime :execute_at
    t.boolean :completed
    t.boolean :has_error
    t.text :error_message
    t.text :error_backtrace
    t.datetime :completed_at

    t.datetime :created_at
  end
end