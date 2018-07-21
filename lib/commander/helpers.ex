defmodule Coxir.Commander.Helpers do
  # Macros
  def reset do
    quote do
      @space :""
      @permit :any
      @channel :any
    end
  end

  def definitions do
    quote do
      # Attributes
      __MODULE__
      |> Module.register_attribute(:commands,
        accumulate: true,
        persist: true
      )
      __MODULE__
      |> Module.register_attribute(:prefix,
        accumulate: true,
        persist: true
      )
      @before_compile Coxir.Commander

      # Nesting
      defmacro __using__(_opts) do
        module = __MODULE__
        quote do
          @commands unquote(module)
          |> Coxir.Commander.Helpers.commands

          @prefix unquote(module)
          |> Coxir.Commander.Helpers.prefix
        end
      end

      # Requires
      require Coxir.Commander
      import Coxir.Commander
      import Coxir.Commander.Utils

      # Handler
      use Coxir
      def handle_event(:foo, :bar) do end
    end
  end

  # Attributes
  def attribute(module, key) do
    module.__info__(:attributes)
    |> Enum.filter(fn
      {^key, _tuple} -> true
      _other -> false
    end)
    |> Enum.map(&elem(&1, 1))
    |> Enum.map(&List.first/1)
  end

  def commands(module) do
    attribute(module, :commands)
  end

  def prefix(module) do
    attribute(module, :prefix)
    |> List.first
  end

  # Building
  def inject({:when, meta, params}, body) do
    [{name, _meta, arguments} | rest] = params
    arguments = arguments || []
    context = meta[:context]
    arguments = [
      {:message, [], context}
      | arguments
    ]
    params = [{name, meta, arguments} | rest]
    arities = aritier(arguments)
    tuple = {:when, meta, params}
    func = {:def, meta, [tuple, body]}

    {name, func, arities}
  end
  def inject({name, meta, arguments}, body) do
    arguments = arguments || []
    context = meta[:context]
    arguments = [
      {:message, [], context}
      | arguments
    ]
    arities = aritier(arguments)
    tuple = {name, meta, arguments}
    func = {:def, meta, [tuple, body]}

    {name, func, arities}
  end

  defp aritier(arguments) do
    optional = arguments
    |> Enum.count(
      fn {name, _meta, _params} ->
        name == :\\
      end
    )
    maximum = arguments
    |> length

    minimum = maximum
    |> :erlang.-(optional)

    minimum..maximum
    |> Enum.map(& &1)
  end
end
