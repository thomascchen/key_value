defmodule KeyValue.RegistryTest do
  use ExUnit.Case, async: true

  setup context do
    {:ok, _} = KeyValue.Registry.start_link(context.test)
    {:ok, registry: context.test}
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

    # Do a call to ensure the registry processed the DOWN message
    _ = KeyValue.Registry.create(registry, "bogus")
    assert KeyValue.Registry.lookup(registry, "shopping") == :error
  end

  test "removes bucket on crash", %{registry: registry} do
    KeyValue.Registry.create(registry, "shopping")
    {:ok, bucket} = KeyValue.Registry.lookup(registry, "shopping")

    # Kill the bucket and wait for the notification
    Process.exit(bucket, :shutdown)

    # Wait until the bucket is dead
    ref = Process.monitor(bucket)
    assert_receive {:DOWN, ^ref, _, _, _}

    # Do a call to ensure the registry processed the DOWN message
    _ = KeyValue.Registry.create(registry, "bogus")
    assert KeyValue.Registry.lookup(registry, "shopping") == :error
  end
end
