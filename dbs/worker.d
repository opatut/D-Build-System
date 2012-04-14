/*
 *  This file is part of the D Build System by Paul Bienkowski ("DBS").
 *
 *  DBS is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  DBS is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with DBS.  If not, see <http://www.gnu.org/licenses/>.
 */

module dbs.worker;

import core.thread;
import dbs.target;

class WorkerQueue {
private:
    int _initialQueueSize;

public:
    WorkerThread[] queue;
    int maxWorkers = 3;
    
    @property float progress() {
        return (_initialQueueSize - queue.length) * 1.0 / _initialQueueSize;
    }
    
    void workerThreadFinished(WorkerThread thread) {
    
    }
    
    /**
     * Starts workers in a loop, and waits until the queue is finished.
     */
    bool work() {
        return true;
    }
}

class WorkerThread : Thread {
    WorkerQueue queue;
    DModule mod;
    
    this(WorkerQueue queue, DModule mod) { 
        this.queue = queue;
        this.mod = mod;
        super(&run);
    } 
    
private: 
    void run() { 
        mod.compile();
        queue.workerThreadFinished(this);
    }
}