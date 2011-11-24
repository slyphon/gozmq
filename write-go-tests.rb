#!/usr/bin/env ruby

SETTER_MAP = {
  'uint64'  => 'SetSockOptUInt64',
  'int64'   => 'SetSockOptInt64',
  'string'  => 'SetSockOptString',
  'int'     => 'SetSockOptInt'
}

GETTER_MAP = {
  'uint64'  => 'GetSockOptUInt64',
  'int64'   => 'GetSockOptInt64',
  'string'  => 'GetSockOptString',
  'int'     => 'GetSockOptInt'
}


def p_get_test(camelname, const, type, setval=nil, socktype='PULL')
  output = []

  getter_fname = "Get#{camelname}"
  getopt_fname = GETTER_MAP[type.to_s]
  setopt_fname = SETTER_MAP[type.to_s]

  puts <<-EOS
func Test#{getter_fname}(t *testing.T) {
    te := NewTestEnv(t)
    defer te.Close()
    s := te.NewSocket(#{socktype})
    defer s.Close()

  EOS

  if setval
    puts <<-EOS
    setval := #{setval}

    e := s.#{setopt_fname}(#{const}, setval)

    if e != nil {
      t.Errorf("#{setopt_fname} got error setting value: %q", e)
      return
    }

    v, e := s.#{getter_fname}()

    if e != nil {
      t.Errorf("Got error trying to #{getter_fname}, %q", e)
      return
    }

    if v != setval {
        t.Errorf("#{getter_fname} did not get correct value, expected: %q, actual: %q", setval, v)
    }
    EOS

  else
    puts <<-EOS

    expect, xe := s.#{getopt_fname}(#{const})

    if xe != nil {
      t.Errorf("#{getopt_fname} got error getting value for #{const}: %q", xe)
      return
    }

    actual, ae := s.#{getter_fname}()

    if ae != nil {
      t.Errorf("Got error trying to #{getter_fname}, %q", ae)
      return
    }

    if expect != actual {
        t.Errorf("#{getter_fname} did not get correct value, expected: %q, actual: %q", expect, actual)
    }

    EOS
  end

  puts "}\n\n"
end

p_get_test 'HWM',               'HWM',                'uint64', 42
p_get_test 'SocketType',        'TYPE',               'uint64'
p_get_test 'Rcvmore',           'RCVMORE',            'uint64'
p_get_test 'Swap',              'SWAP',               'int64',  1024
p_get_test 'Affinity',          'AFFINITY',           'uint64', 1
p_get_test 'Identity',          'IDENTITY',           'string', %q["Clark Kent"]
p_get_test 'Rate',              'RATE',               'int64'
p_get_test 'RecoveryIvl',       'RECOVERY_IVL',       'int64',  5
p_get_test 'RecoveryIvlMsec',   'RECOVERY_IVL_MSEC',  'int64',  12345
p_get_test 'GetMcastLoop',      'MCAST_LOOP',         'int64',  0
p_get_test 'Sndbuf',            'SNDBUF',             'uint64', (64 * 1024)
p_get_test 'Rcvbuf',            'RCVBUF',             'uint64', (54 * 1024)
p_get_test 'Linger',            'LINGER',             'int',    0



