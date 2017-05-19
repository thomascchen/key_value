defmodule KeyValue do
  use Application

  def start(_type, _args) do
    KeyValue.Supervisor.start_link
  end
end
