###############################################################################
# Session.pm - Documentation and Copyright are after __END__.
###############################################################################

package POE::Session;

use strict;
use Carp;

#------------------------------------------------------------------------------

sub new {
  my ($type, $kernel, %states) = @_;

  my $self = bless {
                    'kernel'    => $kernel,
                    'namespace' => { },
                   }, $type;

  while (my ($state, $handler) = each(%states)) {
    $self->register_state($state, $handler);
  }

  if (exists $self->{'states'}->{'_start'}) {
    $kernel->session_alloc($self);
  }
  elsif (exists $self->{'namespace'}->{'_kernel_debug'}) {
    carp "discarding session $self - no '_start' state";
  }

  undef;
}

#------------------------------------------------------------------------------

sub DESTROY {
  my $self = shift;
  delete $self->{'kernel'};
  delete $self->{'namespace'};
  delete $self->{'states'};
}

#------------------------------------------------------------------------------

sub _invoke_state {
  my ($self, $kernel, $source_session, $state, $etc) = @_;

  if (exists $self->{'states'}->{$state}) {
    &{$self->{'states'}->{$state}}($kernel, $self->{'namespace'},
                                   $source_session, @$etc
                                  );
  }
  elsif (exists $self->{'states'}->{'_default'}) {
    &{$self->{'states'}->{'_default'}}($kernel, $self->{'namespace'},
                                       $source_session, $state, @$etc
                                      );
  }
}

#------------------------------------------------------------------------------

sub register_state {
  my ($self, $state, $handler) = @_;

  if (ref($handler) eq 'CODE') {
    carp "redefining state($state) for session($self)"
      if (exists $self->{'states'}->{$state});
    $self->{'states'}->{$state} = $handler;
  }
  else {
    carp "state($state) for session($self) is not code - not registered";
  }
}

###############################################################################
1;
__END__

Documentation: To be.

Copyright 1998 Rocco Caputo <troc@netrus.net>.  All rights reserved.
This is a pre-release version.  Redistribution and modification are
prohibited.
