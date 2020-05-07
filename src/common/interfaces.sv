// ------------------------------------ //
// -------------- FIFO IF ------------- //
// ------------------------------------ //

interface common_sync_fifo_if ();

parameter DW = 32;

parameter DWI  = 1;
parameter DWO  = 1;

parameter DL  = 2;

  typedef struct packed {
  logic [DW*DWI-1:0] wdata;
  logic              write;
  logic              read;
  logic              clr;
  } FIFO_M;

  typedef struct packed {
  logic [DW*DWO-1:0]  rdata;
  logic               nfull;
  logic               nempty;
  logic [DL:0]        free;
  logic [DL:0]        occ;
  } FIFO_S;

FIFO_M m;
FIFO_S s;

modport master (
  output m,
  input  s
  );

modport slave (
  output s,
  input  m
  );
        
endinterface


// ---------------------------------- //
// -------------- VR IF ------------- //
// ---------------------------------- //

// Generic interface with valid-ready handshaking

interface vr_if();

    parameter NV         = 1          ; // Number of valid
    parameter NR         = 1          ; // Number of ready
    parameter ND         = 1          ; // Number of data buses
    parameter type DTYPE = logic [3:0];

    logic [NV-1:0] valid;
    logic [NR-1:0] ready;
    DTYPE [ND-1:0] data ;

    modport master (
        input  ready,
        output valid, data
    );

    modport slave (
        input  valid, data,
        output ready
    );

    // Interface without handshaking
    modport master_vd (        
        output valid, data
    );

    modport slave_vd (
        input  valid, data
    );

    // Interface without data
    
    modport master_vr (
        input  ready,
        output valid
    );

    modport slave_vr (
        input  valid,
        output ready
    );

    modport monitor (
        input valid, data, ready
    );
       
endinterface