# reports/run.json.jbuilder

json.report do
  json.result render(partial: 'result', formats: :html)
end
