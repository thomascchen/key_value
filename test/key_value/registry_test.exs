defmodule KeyValue.RegistryTest do
  use ExUnit.Case, async: true

  setup context do
    {:ok, registry} = KeyValue.Registry.start_link(context.test)
    {:ok, registry: registry}
  end

  test "spawns buckets", %{registry: registry} do
    assert KeyValue.Registry.lookup(registry, "shopping") == :error

    KeyValue.Registry.create(registry, "shopping")
    assert {:ok, bucket} = KeyValue.Registry.lookup(registry, "shopping")

    KeyValue.Bucket.put(bucket, "milk", 1)
    assert KeyValue.Bucket.get(bucket, "milk") == 1
  end

  test "removes buckets on exit", %{registry: registry} do
    KeyValue.Registry.create(registry, "shopping")
    {:ok, bucket} = KeyValue.Registry.lookup(registry, "shopping")
    Agent.stop(bucket)
    assert KeyValue.Registry.lookup(registry, "shopping") == :error
  end

  test "removes bucket on crash", %{registry: registry} do
    KeyValue.Registry.create(registry, "shopping")
    {:ok, bucket} = KeyValue.Registry.lookup(registry, "shopping")

    # Stop the bucket with non-normal reason
    ref = Process.monitor(bucket)
    Process.exit(bucket, :shutdown)

    # Wait until the bucket is dead
    assert_receive {:DOWN, ^ref, _, _, _}

    assert KeyValue.Registry.lookup(registry, "shopping") == :error
  end
end
