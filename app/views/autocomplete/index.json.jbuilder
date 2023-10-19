# autocomplete/index.json.jbuilder

json.array!(@records) do |record|
  json.id record.id
  json.label record.send(@label_method)
end
