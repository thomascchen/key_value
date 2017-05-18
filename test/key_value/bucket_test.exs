defmodule KeyValue.BucketTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, bucket} = KeyValue.Bucket.start_link
    {:ok, bucket: bucket}
  end

  test "stores values by key", %{bucket: bucket} do
    assert KeyValue.Bucket.get(bucket, "milk") == nil

    KeyValue.Bucket.put(bucket, "milk", 3)
    assert KeyValue.Bucket.get(bucket, "milk") == 3
  end

  test "deletes value of key if it exists", %{bucket: bucket} do
    KeyValue.Bucket.put(bucket, "milk", 3)

    assert KeyValue.Bucket.delete(bucket, "bread") == nil
    assert KeyValue.Bucket.delete(bucket, "milk") == 3
    assert KeyValue.Bucket.get(bucket, "milk") == nil
  end
end
