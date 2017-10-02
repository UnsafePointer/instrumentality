performance$target:::begin_benchmark
{
  time = timestamp;
  tag = copyinstr(arg0);
  tag_times[tag] = time;
}

performance$target:::end_benchmark
/ controller_init_times[copyinstr(arg0)] != 0 /
{
  tag = copyinstr(arg0);
  time = (timestamp - tag_times[tag]);
  printf("%s:%d\n", tag, time);
}
