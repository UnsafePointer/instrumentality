performance$target:::controller_init
{
  time = timestamp;
  controller = copyinstr(arg0);
  controller_init_times[controller] = time;
}

performance$target:::controller_did_appear
/ controller_init_times[copyinstr(arg0)] != 0 /
{
  controller = copyinstr(arg0);
  time = (timestamp - controller_init_times[controller]);
  printf("%s:%d\n", controller, time);
}
