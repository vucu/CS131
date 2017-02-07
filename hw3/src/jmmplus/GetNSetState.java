package jmmplus;
import java.util.concurrent.atomic.AtomicIntegerArray;

class GetNSetState implements State {
    private byte maxval;
    private AtomicIntegerArray atomicArray;

	// Helper class to create AtomicIntegerArray from byte array
	// With an intermediate int array because the constructor only
	// takes in an int array
	private void init(byte[] v){
    	int[] intArray = new int[v.length];
    	for(int i = 0; i < v.length; i++){
    		intArray[i] = v[i];
		}
		atomicArray = new AtomicIntegerArray(intArray);
	}


    GetNSetState(byte[] v) { 
    	maxval = 127;
    	init(v);
    }

    GetNSetState(byte[] v, byte m) { 
    	maxval = m;
    	init(v);
    }

    public int size() { return atomicArray.length(); }

	// Downcast the array of ints in the AtomicIntegerArray to bytes
    public byte[] current() { 
		byte[] ret = new byte[atomicArray.length()];
		for(int i = 0; i < ret.length; i++){
			ret[i] = (byte) atomicArray.get(i);
		}
		return ret;
	}

	// Use the AtomicIntegerArray to get and set the values
	// of the array in an atomic manner
	public boolean swap(int i, int j) {
		if (atomicArray.get(i) <= 0 || atomicArray.get(j) >= maxval) {
			return false;
		}
		atomicArray.getAndDecrement(i);
		atomicArray.getAndIncrement(j);
		return true;
	}
}