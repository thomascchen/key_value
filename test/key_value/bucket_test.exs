defmodule KeyValue.BucketTest do
  use ExUnit.Case, async: true

  test "stores values by key" do
    {:ok, bucket} = KeyValue.Bucket.start_link
    assert KeyValue.Bucket.get(bucket, "milk") == nil

    KeyValue.Bucket.put(bucket, "milk", 3)
    assert KeyValue.Bucket.get(bucket, "milk") == 3
  end
end
