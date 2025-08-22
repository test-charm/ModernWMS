// 日志处理
export function parseOperation(config): string {
    let str = ''
    const URL = config.url
    const REQ_METHOD = config.method
    const RES = config.data || config.params
    if (URL === '/company') {
        if (REQ_METHOD === 'post') {
            str = `[新增] 名称为${ RES.company_name }的公司`
        } else if (REQ_METHOD === 'put') {
            str = `[修改] 名称为${ RES.company_name }的公司信息`
        } else if (REQ_METHOD === 'delete') {
            str = `[删除] 名称为${ RES.logTemp }的公司`
        }
    } else if (URL === '/userrole') {
        if (REQ_METHOD === 'post') {
            str = `[新增] 名称为${ RES.role_name }的角色`
        } else if (REQ_METHOD === 'put') {
            str = `[修改] 名称为${ RES.role_name }的角色信息`
        } else if (REQ_METHOD === 'delete') {
            str = `[删除] 名称为${ RES.logTemp }的角色`
        }
    } else if (URL === '/rolemenu') {
        if (REQ_METHOD === 'post') {
            str = `[新增] 名称为${ RES.role_name }的角色权限`
        } else if (REQ_METHOD === 'put') {
            str = `[修改] 名称为${ RES.role_name }的角色权限信息`
        } else if (REQ_METHOD === 'delete') {
            str = `[删除] 名称为${ RES.logTemp }的角色权限`
        }
    } else if (URL === '/user') {
        if (REQ_METHOD === 'post') {
            str = `[新增] 名称为${ RES.user_name }的用户`
        } else if (REQ_METHOD === 'put') {
            str = `[修改] 名称为${ RES.user_name }的用户信息`
        } else if (REQ_METHOD === 'delete') {
            str = `[删除] 名称为${ RES.logTemp }的用户`
        }
    } else if (URL === '/user/reset-pwd') {
        str = `[重置] 名称为${ RES.logTemp.join(', ') }的用户密码`
    } else if (URL === '/category') {
        if (REQ_METHOD === 'post') {
            str = `[新增] 名称为${ RES.category_name }的商品类别`
        } else if (REQ_METHOD === 'put') {
            str = `[修改] 名称为${ RES.category_name }的商品类别信息`
        } else if (REQ_METHOD === 'delete') {
            str = `[删除] 名称为${ RES.logTemp }的商品类别`
        }
    } else if (URL === '/spu') {
        if (REQ_METHOD === 'post') {
            str = `[新增] 商品编号为${ RES.spu_name }的商品`
        } else if (REQ_METHOD === 'put') {
            str = `[修改] 商品编号为${ RES.spu_name }的商品信息`
        } else if (REQ_METHOD === 'delete') {
            str = `[删除] 商品编号为${ RES.logTemp }的商品`
        }
    } else if (URL === '/spu/sku-safety-stock') {
        if (REQ_METHOD === 'put') {
            str = `[修改] 商品规格编号为${ RES.sku_id }的商品安全库存`
        }
    } else if (URL === '/supplier') {
        if (REQ_METHOD === 'post') {
            str = `[新增] 名称为${ RES.supplier_name }的供应商`
        } else if (REQ_METHOD === 'put') {
            str = `[修改] 名称为${ RES.supplier_name }的供应商信息`
        } else if (REQ_METHOD === 'delete') { 
            str = `[删除] 名称为${ RES.logTemp }的供应商`
        }
    } else if (URL === '/PrintSolution') {
        if (REQ_METHOD === 'post') {
            str = `[新增] 名称为${ RES.solution_name }的打印方案`
        } else if (REQ_METHOD === 'put') {
            str = `[修改] 名称为${ RES.solution_name }的打印方案信息`
        } else if (REQ_METHOD === 'delete') {
            str = `[删除] 名称为${ RES.logTemp }的打印方案`
        }
    } else if (URL === '/goodsowner') {
        if (REQ_METHOD === 'post') {
            str = `[新增] 名称为${ RES.goods_owner_name }的货主`
        } else if (REQ_METHOD === 'put') {
            str = `[修改] 名称为${ RES.goods_owner_name }的货主信息`
        } else if (REQ_METHOD === 'delete') {
            str = `[删除] 名称为${ RES.logTemp }的货主`
        }
    } else if (URL === '/freightfee') {
        if (REQ_METHOD === 'post') {
            str = `[新增] 名称为${ RES.carrier }的承运商从${ RES.departure_city }到${ RES.arrival_city }的运费信息`
        } else if (REQ_METHOD === 'put') {
            str = `[修改] 名称为${ RES.carrier }的承运商从${ RES.departure_city }到${ RES.arrival_city }的运费信息`
        } else if (REQ_METHOD === 'delete') {
            str = `[删除] 名称为${ RES.logTemp.carrier }的承运商从${ RES.logTemp.departure }到${ RES.logTemp.arrival }的运费信息`
        }
    } else if (URL === '/customer') {
        if (REQ_METHOD === 'post') {
            str = `[新增] 名称为${ RES.customer_name }的客户`
        } else if (REQ_METHOD === 'put') {
            str = `[修改] 名称为${ RES.customer_name }的客户信息`
        } else if (REQ_METHOD === 'delete') {
            str = `[删除] 名称为${ RES.logTemp }的客户`
        }
    } else if (URL === '/warehouse') {
        if (REQ_METHOD === 'post') {
            str = `[新增] 名称为${ RES.warehouse_name }的仓库`
        } else if (REQ_METHOD === 'put') {
            str = `[修改] 名称为${ RES.warehouse_name }的仓库信息`
        } else if (REQ_METHOD === 'delete') {
            str = `[删除] 名称为${ RES.logTemp }的仓库`
        }
    } else if (URL === '/warehousearea') {
        if (REQ_METHOD === 'post') {
            str = `[新增] ${ RES.warehouse_name }仓库中的名称为${ RES.area_name }的库区`
        } else if (REQ_METHOD === 'put') {
            str = `[修改] ${ RES.warehouse_name }仓库中的名称为${ RES.area_name }的库区信息`
        } else if (REQ_METHOD === 'delete') {  
            str = `[删除] ${ RES.logTemp.warehouse }仓库中的名称为${ RES.logTemp.area }的库区`
        }
    } else if (URL === '/goodslocation') {
        if (REQ_METHOD === 'post') {
            str = `[新增] ${ RES.warehouse_name }仓库中${ RES.warehouse_area_name }库区下的编码为${ RES.location_name }的库位`
        } else if (REQ_METHOD === 'put') {
            str = `[修改] ${ RES.warehouse_name }仓库中${ RES.warehouse_area_name }库区下的编码为${ RES.location_name }的库位信息`
        } else if (REQ_METHOD === 'delete') {
            str = `[删除] ${ RES.logTemp.warehouse }仓库中${ RES.logTemp.area }库区的编码为${ RES.logTemp.location }的库位`
        }
    // ToDo：收货管理
    // ToDo：发货管理
    } else if (URL === '/stockprocess') {
        if (REQ_METHOD === 'post') {
            str = '[新增] 一份仓内加工的作业'
        } else if (REQ_METHOD === 'put') {
            str = `[修改] 作业单号为${ RES.process_code }的作业信息`
        } else if (REQ_METHOD === 'delete') {
            str = `[删除] 作业单号为${ RES.logTemp }的作业`
        }
    } else if (URL === '/stockprocess/process-confirm') {
        str = `[确认] 作业单号为${ RES.logTemp }的作业加工`
    } else if (URL === '/stockprocess/adjustment-confirm') {
        str = `[确认] 作业单号为${ RES.logTemp }的作业调整`
    } else if (URL === '/stockmove') {
        if (REQ_METHOD === 'post') {
            str = '[新增] 一份库存移动的作业'
        } else if (REQ_METHOD === 'put') {
            str = `[确认] 作业单号为${ RES.logTemp }的移库`
        } else if (REQ_METHOD === 'delete') {  
            str = `[删除] 作业单号为${ RES.logTemp }的移库作业`
        }
    } else if (URL === '/stockfreeze') {
        if (REQ_METHOD === 'post') {
            if (RES.job_type) {
                str = `[冻结] 一份商品编号为${ RES.spu_code }，规格编号为${ RES.sku_code }的库存`
            } else {
                str = `[解冻] 一份商品编号为${ RES.spu_code }，规格编号为${ RES.sku_code }的库存`
            }
        }
    } else if (URL === '/stocktaking') {
        if (REQ_METHOD === 'post') {
            str = '[新增] 一份库存盘点的作业'
        } else if (REQ_METHOD === 'put') {
            str = `[确认] 作业单号为${ RES.job_code }的库存盘点信息`
        } else if (REQ_METHOD === 'delete') {
            str = `[删除] 作业单号为${ RES.logTemp }的库存盘点作业`
        }
    } else if (URL === '/stocktaking/adjustment-confirm') {
        str = `[确认] 作业单号为${ RES.logTemp }的库存盘点调整`
    }
    return str
}