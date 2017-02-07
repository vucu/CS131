package jmmplus;
import java.util.concurrent.atomic.AtomicIntegerArray;

class GetNSetState implements State {
	private AtomicIntegerArray value;
	private byte maxval;

	private void init(byte[] v){
		int[] a = new int[v.length];
		for(int i = 0; i < v.length; i++){
			a[i] = v[i];
		}
		value = new AtomicIntegerArray(a);
	}


	GetNSetState(byte[] v) { 
		maxval = 127;
		init(v);
	}

	GetNSetState(byte[] v, byte m) { 
		maxval = m;
		init(v);
	}

	public int size() { return value.length(); }

	public byte[] current() { 
		byte[] a = new byte[value.length()];
		for(int i = 0; i < a.length; i++){
			a[i] = (byte) value.get(i);
		}
		return a;
	}

	public boolean swap(int i, int j) {
		if (value.get(i) <= 0 || value.get(j) >= maxval) {
			return false;
		}
		value.getAndDecrement(i);
		value.getAndIncrement(j);
		return true;
	}
}