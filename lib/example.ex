defmodule Example do
  @tree_program "🎄🎄🎄🎄🎄🎁☃️🎄☃️☃️🌲🌲🌲🌲🌲🌲🎄🎅⛄🤶🎄🎅⛄🤶🎄🎅⛄🤶🎄🎅⛄🤶🎄🎅🌲🌲🌲🌲☃️🎄🎄🎄🎄⛄🤶🌲🌲🌲🌲🎅🎄🎄🎄🎄🎄🎅
🌲🌲🌲🌲☃️🎄☃️🎄🎄🎄⛄🤶🌲🌲🌲🎅🎄🎄🎄☃️🌲🌲🌲⛄🤶🌲🎅🎄☃️🌲🌲⛄🎅🎄🎄🎅⛄🤶🎄☃️🌲🌲🌲⛄🤶🎄🎄🎄🎅🌲🌲🌲☃️🎄🎄
🎄⛄🤶🌲🎅🌲⛄🎅🎄🎄🎄⛄🌲🌲🌲🎅⛄🤶🤶☃️🎄⛄🤶🌲⛄🤶🎄🎄🎄☃️🌲🌲🌲🌲🤶🎄🎄🎄🎄🎄🎄☃️🌲🌲🎄🎄🎄☃️☃️☃️☃️☃️☃️☃️🎅
🎄☃️☃️☃️☃️☃️🌲⛄🤶🎄⛄⛄⛄🌲🌲🌲🌲🎄🎄🎄☃️☃️☃️☃️☃️☃️☃️🎅🎄🎄☃️☃️☃️☃️☃️🌲🌲⛄🤶🌲🌲🌲🎄🎄🎄☃️☃️☃️☃️☃️☃️☃️☃️☃️☃️
🌲🌲🌲🎅⛄🎄🎄🎄🎄🎄🎄☃️🎄☃️🎄🎄🎄🎄🎄🎄🎄🎄🎄☃️🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🤶🎄🎄🎅⛄🎄🎄🎄🎄🎄🎄🎄☃️🌲🌲
🌲🌲🌲🌲🌲🤶🎄🎄🎄🎄☃️🎅🎄🎅⛄🎄☃️🎄🎄🎄☃️🎄🎄☃️🌲🌲🌲🌲🌲🌲🤶🎄🎄🎅⛄🎄☃️🎄🎄☃️🌲🌲🌲🤶🎄🎄🎅⛄🌲🌲🌲🌲🌲🌲🌲
🔔🎄🎄🎄🎄🎄🎄🎄🤶🎄🎅⛄🌲🌲🌲🌲🌲🌲🌲🔔🎄🎄🎄🎄🎄🎄🎄🤶🎄🎅⛄🌲🌲🌲🌲🌲🌲🌲🌲🌲🔔🎄🎄🎄🎄🎄🎄🎄🎄🎄🤶🌲🌲🌲🌲
🌲🌲🌲🌲🌲🌲🔔🎄🎄🎄🎄🎄🎄🎄🎄🎄🎄🌲🌲🌲🌲🌲🎅⛄🌲☃️🎄🤶🌲⛄🎄🎄🎄🎅⛄🌲☃️🎄🤶🌲☃️☃️🌲🌲🌲⛄🤶🎄🎄🎄🎄🎄🎄🎄🎄
🎄🎄⛄🎅🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🔔🎄🎄🎄🎄🎄🎄🎄🎄🎄🎄🎄🎄⛄🤶🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🌲🔔🔔🔔"

  def run_tree do
    io = self()
    spawn(fn -> Bfxmas.exec(@tree_program, io); end)

    io_loop(:char)
  end

  def run_own do
    io = self()
    spawn(fn -> Bfxmas.exec(IO.gets("Enter a program:\n"), io); end)
    io_loop(:num)
  end

  def io_loop(output_type) do
    receive do
      {:print, num} -> output(output_type, num); io_loop(output_type)
      {:read, back} -> send(back, {:num, read_number()}); io_loop(output_type)
      {:finish, tape} -> tape
    end
  end

  def output(:char, num) do
    IO.write(List.to_string([num]))
  end

  def output(:num, num) do
    IO.write(num) 
  end

  def read_number do
    Integer.parse(IO.gets("Enter a Number (n >= 2):\n\n"), 10)
    |> case do
      {n, "\n"} when n > 1 -> n
      _ -> read_number()
    end
  end
end