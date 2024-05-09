<!-- stock age Statistic -->
<template>
  <div class="container">
    <div>
      <!-- Main Content -->
      <v-card class="mt-5">
        <v-card-text>
          <v-window v-model="data.activeTab">
            <v-window-item>
              <div class="operateArea">
                <v-row no-gutters>
                  <!-- Operate Btn -->
                  <v-col cols="3" class="col">
                    <BtnGroup :authority-list="data.authorityList" :btn-list="btnList" />
                  </v-col>

                  <!-- Search Input -->
                  <v-col cols="9">
                    <search-group
                      ref="searchGroupRef"
                      v-model="data.searchForm"
                      :menu-name="data.menu_name"
                      i18n-prefix="wms.stockageStatistic"
                      @sure-search="method.sureSearch"
                    />
                  </v-col>
                </v-row>
              </div>

              <!-- Table -->
              <div
                class="mt-5"
                :style="{
                  height: cardHeight
                }"
              >
                <vxe-table ref="xTable" :column-config="{ minWidth: '120px' }" :data="data.tableData" :height="tableHeight" align="center">
                  <template #empty>
                    {{ i18n.global.t('system.page.noData') }}
                  </template>
                  <vxe-column type="seq" width="60"></vxe-column>
                  <vxe-column field="warehouse_name" :title="$t('wms.stockageStatistic.warehouse_name')"></vxe-column>
                  <vxe-column field="location_name" :title="$t('wms.stockageStatistic.location_name')"></vxe-column>
                  <vxe-column field="spu_code" :title="$t('wms.stockageStatistic.spu_code')"></vxe-column>
                  <vxe-column field="spu_name" :title="$t('wms.stockageStatistic.spu_name')"></vxe-column>
                  <vxe-column field="sku_code" :title="$t('wms.stockageStatistic.sku_code')"></vxe-column>
                  <vxe-column field="sku_name" :title="$t('wms.stockageStatistic.sku_name')"></vxe-column>
                  <vxe-column field="goods_owner_name" :title="$t('wms.stockageStatistic.goods_owner_name')"></vxe-column>
                  <vxe-column field="series_number" :title="$t('wms.stockageStatistic.series_number')"></vxe-column>
                  <vxe-column field="qty" :title="$t('wms.stockageStatistic.qty')"></vxe-column>
                  <vxe-column field="price" :title="$t('wms.stockageStatistic.price')"></vxe-column>
                  <vxe-date-column field="expiry_date" :title="$t('wms.stockageStatistic.expiry_date')"></vxe-date-column>
                  <vxe-date-column field="putaway_date" :title="$t('wms.stockageStatistic.putaway_date')"></vxe-date-column>
                  <vxe-column field="stock_age" :title="$t('wms.stockageStatistic.stock_age')"></vxe-column>
                </vxe-table>
                <custom-pager
                  :current-page="data.tablePage.pageIndex"
                  :page-size="data.tablePage.pageSize"
                  perfect
                  :total="data.tablePage.total"
                  :page-sizes="PAGE_SIZE"
                  :layouts="PAGE_LAYOUT"
                  @page-change="method.handlePageChange"
                >
                </custom-pager>
              </div>
            </v-window-item>
          </v-window>
        </v-card-text>
      </v-card>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { computed, ref, reactive, watch, onMounted } from 'vue'
import { VxePagerEvents } from 'vxe-table'
import { computedCardHeight, computedTableHeight } from '@/constant/style'
import { PAGE_SIZE, PAGE_LAYOUT, DEFAULT_PAGE_SIZE } from '@/constant/vxeTable'
import { DEBOUNCE_TIME } from '@/constant/system'
import { getMenuAuthorityList } from '@/utils/common'
import { SearchObject, btnGroupItem } from '@/types/System/Form'
import i18n from '@/languages/i18n'
import customPager from '@/components/custom-pager.vue'
import { exportData } from '@/utils/exportTable'
import BtnGroup from '@/components/system/btnGroup.vue'
import { list as getStockAgeStatisticList } from '@/api/wms/stockageStatistic'
import { hookComponent } from '@/components/system'
import { StockAgeStatisticVo } from '@/types/WMS/StockAgeStatistic'
import SearchGroup from '@/components/system/search-group.vue'

const xTable = ref()
const searchGroupRef = ref()

const data = reactive({
  showDialog: false,
  timer: ref<any>(null),
  activeTab: null,
  searchForm: {
    spu_code: '',
    spu_name: '',
    sku_code: '',
    sku_name: '',
    warehouse_name: '',
    location_name: '',
    stock_age_from: '',
    stock_age_to: '',
    expiry_date_from: '',
    expiry_date_to: ''
  },
  tableData: ref<StockAgeStatisticVo[]>([]),
  tablePage: reactive({
    total: 0,
    pageIndex: 1,
    pageSize: DEFAULT_PAGE_SIZE,
    searchObjects: ref<Array<SearchObject>>([])
  }),
  btnList: [] as btnGroupItem[],
  // Menu operation permissions
  authorityList: getMenuAuthorityList(),
  // Local search criteria settings
  menu_name: 'stockageStatistic'
})

const method = reactive({
  // get data
  list: async () => {
    const searchForm = {}

    for (const item of Object.keys(data.searchForm)) {
      if (data.searchForm[item]) {
        searchForm[item] = data.searchForm[item]
      }
    }

    const { data: res } = await getStockAgeStatisticList({ ...data.tablePage, ...searchForm })
    if (!res.isSuccess) {
      hookComponent.$message({
        type: 'error',
        content: res.errorMessage
      })
      return
    }
    data.tableData = res.data.rows
    data.tablePage.total = res.data.totals
  },

  // Refresh data
  refresh: () => {
    method.list()
  },

  // Shut add or update dialog
  closeDialog: () => {
    data.showDialog = false
  },

  // Pagination function
  handlePageChange: ref<VxePagerEvents.PageChange>(({ currentPage, pageSize }) => {
    data.tablePage.pageIndex = currentPage
    data.tablePage.pageSize = pageSize
    method.refresh()
  }),

  // Export Table
  exportTable: () => {
    const $table = xTable.value
    exportData({
      table: $table,
      filename: i18n.global.t('router.sideBar.stockageStatistic'),
      columnFilterMethod({ column }: any) {
        return !['checkbox'].includes(column?.type) && !['operate'].includes(column?.field)
      }
    })
  },

  sureSearch: () => {
    // data.tablePage.searchObjects = setSearchObject(data.searchForm)
    method.refresh()
  },

  // Set Search
  handleSetSearch: () => {
    searchGroupRef.value.openDialog()
  }
})

const cardHeight = computed(() => computedCardHeight({ hasTab: false }))
const tableHeight = computed(() => computedTableHeight({ hasTab: false }))
const btnList = computed(() => [
  {
    name: i18n.global.t('system.page.refresh'),
    icon: 'mdi-refresh',
    code: '',
    click: method.refresh
  },
  {
    name: i18n.global.t('system.page.export'),
    icon: 'mdi-export-variant',
    code: 'export',
    click: method.exportTable
  },
  {
    name: i18n.global.t('system.page.setSearch'),
    icon: 'mdi-cog',
    code: '',
    click: method.handleSetSearch
  }
])

watch(
  () => data.searchForm,
  () => {
    // debounce
    if (data.timer) {
      clearTimeout(data.timer)
    }
    data.timer = setTimeout(() => {
      data.timer = null
      method.sureSearch()
    }, DEBOUNCE_TIME)
  },
  {
    deep: true
  }
)
</script>

<style scoped lang="less">
.operateArea {
  width: 100%;
  min-width: 760px;
  display: flex;
  align-items: center;
  border-radius: 10px;
  padding: 0 10px;
}

.col {
  display: flex;
  align-items: center;
}
</style>
