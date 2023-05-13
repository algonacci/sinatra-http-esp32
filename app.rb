require "sinatra"
require "puma"
require "google/cloud/firestore"
require "json"

set :server, :puma

firestore = Google::Cloud::Firestore.new(
  project_id: "demoandroidmarketplace",
  credentials: "serviceAccount.json"
)

post "/data" do
  data = JSON.parse(request.body.read)
  now = Time.now.utc
  data["updatedAt"] = now.to_s
  user_id = data["user_id"]
  device_id = data["device_id"]

  filtered_data = {
    "moisture" => data["moisture"],
    "tds" => data["tds"],
    "pH" => data["pH"],
    "updatedAt" => data["updatedAt"]
  }

  collection = firestore.col("users").doc(user_id).col("devices")
  document_ref = collection.doc(device_id)

  if document_ref.set(filtered_data)
    content_type :json
    status 200
    { message: "Data received and stored successfully" }.to_json
  else
    content_type :json
    status 500
    { error: "Failed to store data" }.to_json
  end
end

get "/" do
  "Hello, World!"
end
