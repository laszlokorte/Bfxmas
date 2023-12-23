defmodule Bfxmas do
  @empty_tape {[], [0]}

  @bf_right "🎄"
  @bf_left "🌲"
  @bf_inc "☃️"
  @bf_dec "⛄"
  @bf_loop_left "🎅"
  @bf_loop_right "🤶"
  @bf_write "🔔"
  @bf_read "🎁"
  @number_prompt "Enter a Number:\n"
  @program_prompt "Enter a Program:\n"

  def parse(program_string) do
    {[], program_string |> String.graphemes()}
  end

  def tape({[], right}, :left), do: {[], [0 | right]}
  def tape({[l | left], right}, :left), do: {left, [l | right]}

  def tape({left, []}, :right), do: {[0 | left], []}
  def tape({left, [r | right]}, :right), do: {[r | left], right}

  def tape({left, []}, :inc), do: {left, [1]}
  def tape({left, [r | right]}, :inc), do: {left, [r + 1 | right]}

  def tape({left, []}, :dec), do: {left, [-1]}
  def tape({left, [r | right]}, :dec), do: {left, [r - 1 | right]}

  def read_tape({_, []}), do: 0
  def read_tape({_, [r | _]}), do: r

  def write_tape({left, []}, val), do: {left, [val]}
  def write_tape({left, [_ | right]}, val), do: {left, [val | right]}

  def seek({_, [search|_]} = prog, _, search, _, 0), do: prog

  def seek({_, [search|_]} = prog, dir, search, oposite, acc),
    do: seek(tape(prog, dir), dir, search, oposite, acc - 1)

  def seek({_, [oposite|_]} = prog, dir, search, oposite, acc),
    do: seek(tape(prog, dir), dir, search, oposite, acc + 1)

  def seek(prog, dir, search, oposite, acc),
    do: seek(tape(prog, dir), dir, search, oposite, acc)

  def step(@bf_right, pc, tape), do: {:cont, tape(pc, :right), tape(tape, :right)}
  def step(@bf_left, pc, tape), do: {:cont, tape(pc, :right), tape(tape, :left)}
  def step(@bf_inc, pc, tape), do: {:cont, tape(pc, :right), tape(tape, :inc)}
  def step(@bf_dec, pc, tape), do: {:cont, tape(pc, :right), tape(tape, :dec)}
  def step(@bf_write, pc, tape), do: {:print, tape(pc, :right), tape}
  def step(@bf_read, pc, tape), do: {:read, tape(pc, :right), tape}
  
  def step(@bf_loop_left, pc, tape) do 
    if read_tape(tape) == 0 do
      {:cont, seek(tape(pc, :right), :right, @bf_loop_right, @bf_loop_left, 0), tape}
    else
      {:cont, tape(pc, :right), tape}
    end
  end

  def step(@bf_loop_right, pc, tape) do 
    if read_tape(tape) != 0 do
      prev_instruction = tape(pc, :left)
      {:cont, seek(prev_instruction, :left, @bf_loop_left, @bf_loop_right, 0), tape}
    else
      {:cont, tape(pc, :right), tape}
    end
  end

  def step(_, pc, tape), do: {:cont, tape(pc, :right), tape}

  def run({_, []}, tape, io), do: send(io, {:finish, tape})
  def run({_, [c | _]} = pc, tape, io) do
    case step(c, pc, tape) do
      {:cont, pc, tape} -> run(pc, tape, io)
      {:print, pc, tape} -> send(io, {:print, read_tape(tape)}); run(pc, tape, io)
      {:read, pc, tape} -> send(io, {:read, self()}); receive do
        {:num, num} -> run(pc, write_tape(tape, num), io)
      end
    end
  end

  def output(num) do
    IO.write(List.to_string([num])) 
  end

  def read_number do
    Integer.parse(IO.gets(@number_prompt), 10)
    |> case do
      {n, "\n"} -> n
      _ -> read_number()
    end
  end

  def io_loop() do
    receive do
      {:print, num} -> output(num); io_loop()
      {:read, back} -> send(back, {:num, read_number()}); io_loop()
      {:finish, tape} -> tape
    end
  end

  def exec(program) do
    io = self()
    spawn(fn -> 
      exec(program, io)
    end)

    io_loop()
  end

  def exec(program, io) do
    program  |> parse |> run(@empty_tape, io)
  end
end
